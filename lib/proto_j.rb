proto_j_lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(proto_j_lib_path) if File.directory?(proto_j_lib_path) && !$:.include?(proto_j_lib_path)

require 'json'

require 'active_support/inflector'
require 'active_support/core_ext'

require 'proto_j/exception/type_mismatch'
require 'proto_j/associations/collection_proxy'
require 'proto_j/associations/has_many_association'
require 'proto_j/base'
require 'proto_j/utils'
