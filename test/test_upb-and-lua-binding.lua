require('test_pb_pb')

local upb = require "upb"

local def = upb.generated_pool:lookup_msg('cmake_toolset.test_message')

print(string.format('Message full name = %s', def.full_name))
print(string.format('  file = %s', def.file))
print(string.format('  lookup_name = %s', def.lookup_name))
print(string.format('  name = %s', def.name))
print(string.format('  oneof_count = %s', def.oneof_count))
print(string.format('  field_count = %s', def.field_count))
for v in def:fields() do
  if upb.LABEL_REPEATED == v:label() then
    print(string.format('    repeated %s %s = %s', v:type(), v:name(), v:number()))
  else
    print(string.format('    %s %s = %s', v:type(), v:name(), v:number()))
  end
end

local msg1 = def()
msg1.i32 = 123
msg1.i64 = 321
msg1.str = "Hello world!"

local bin_data = upb.encode(msg1)
local msg2 = upb.decode(def, bin_data)
local text_data = upb.text_encode(msg2)

print(text_data)
