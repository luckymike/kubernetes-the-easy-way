SparkleFormation.component(:in_a_vpc) do

  parameters(:vpc_id) do
    type 'String'
    description 'VPC to Join'
  end

  parameters(:vpc_cidr) do
    type 'String'
    description 'VPC CIDR'
  end

  zones = registry!(:zones)

  zones.each do |zone|
    parameters do
      set!(['public_', zone.gsub('-','_'), '_subnet'].join) do
        type 'String'
        description 'Subnet to join'
      end
    end
  end
end
