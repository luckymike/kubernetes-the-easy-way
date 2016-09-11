SparkleFormation.new(:kube_vpc, :inherit => :lazy_vpc__public_subnet_vpc) do
  zones = registry!(:zones)

  parameters(:vpc_cidr) do
    default '10.240.0.0/16'
  end

  zones.each_with_index do |zone, index|
    parameters(['public_', zone.gsub('-', '_'), '_subnet_cidr' ].join) do
      default ['10.240.', index, '.0/24'].join
    end
  end

end
