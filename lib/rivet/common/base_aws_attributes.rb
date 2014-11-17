# encoding: UTF-8

module Rivet
  BASE_AWS_ATTRIBUTES = [
    :iam_instance_profile,
    :block_device_mappings,
    :image_id,
    :key_name,
    :security_groups,
    :instance_type,
    :kernel_id,
    :ramdisk_id,
    :associate_public_ip_address
  ].each { |a| attr_reader a }
end
