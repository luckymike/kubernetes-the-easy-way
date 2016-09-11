SparkleFormation.new(:kube_instances).load(:base, :compute, :in_a_vpc) do

  zones = registry!(:zones)

  parameters(:ssh_key_name) do
    type 'String'
    default ENV['AWS_SSH_KEY']
  end

  resources do
    # Security Group Setup
    kube_security_group do
      type 'AWS::EC2::SecurityGroup'
      properties do
        group_description 'Kubernetes Cluster Security Group'
        vpc_id ref!(:vpc_id)
      end
    end
    kube_vpc do
      type 'AWS::EC2::SecurityGroupIngress'
      properties do
        group_id ref!(:kube_security_group)
        ip_protocol '-1'
        from_port 0
        to_port 65535
        cidr_ip ref!(:vpc_cidr)
      end
    end
    public_ssh do
      type 'AWS::EC2::SecurityGroupIngress'
      properties do
        group_id ref!(:kube_security_group)
        ip_protocol 'tcp'
        from_port 22
        to_port 22
        cidr_ip '0.0.0.0/0'
      end
    end
    kube_mgmt do
      type 'AWS::EC2::SecurityGroupIngress'
      properties do
        group_id ref!(:kube_security_group)
        ip_protocol 'tcp'
        from_port 6443
        to_port 6443
        cidr_ip '0.0.0.0/0'
      end
    end
    kube_egress do
      type 'AWS::EC2::SecurityGroupEgress'
      properties do
        group_id ref!(:kube_security_group)
        ip_protocol '-1'
        from_port 0
        to_port 65535
        cidr_ip '0.0.0.0/0'
      end
    end

    # Instance Profile & Role Permissions
    cfn_role do
      properties do
        policies array!(
          -> {
            policy_name 'kubernetes_iam_policy'
            policy_document do
              statement array!(
                -> {
                  effect 'Allow'
                  action [
                    'ec2:*',
                    'elasticloadbalancing:*',
                    'route53:*',
                    'ecr:*'
                  ]
                  resource '*'
                }
              )
            end
          }
        )
      end
    end

    kube_instance_profile do
      type 'AWS::IAM::InstanceProfile'
      properties do
        path '/kubernetes/'
        roles [ ref!(:cfn_role) ]
      end
    end

    zone = zones.first

    %w( etcd controller worker ).each_with_index do |role, index|

      3.times do |count|

        set!("#{role}_#{count}") do
          type 'AWS::EC2::Instance'
          properties do
            associate_public_ip_address
            availability_zone zones.first
            image_id 'ami-746aba14'
            iam_instance_profile ref!(:kube_instance_profile)
            instance_type 't2.small'
            key_name ref!(:ssh_key_name)
            network_interfaces array!(
              -> {
                associate_public_ip_address true
                device_index 0
                subnet_id ref!(['public_', zone.gsub('-','_'), '_subnet'].join.to_sym)
                group_set [ ref!(:kube_security_group) ]
                private_ip_address [ "10.240.0.", index + 1, count ].join
              }
            )
            tags array!(
              -> {
                key 'Name'
                value "#{role}#{count}"
              }
            )
          end
        end
      end
    end
  end
end
