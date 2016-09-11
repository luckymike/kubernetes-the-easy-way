SparkleFormation.component(:base) do

  set!('AWSTemplateFormatVersion', '2010-09-09')

  parameters do
    stack_creator do
      type 'String'
      default ENV['USER']
    end
  end

  outputs do
    stack_creator do
      value ref!(:stack_creator)
    end
  end
end
