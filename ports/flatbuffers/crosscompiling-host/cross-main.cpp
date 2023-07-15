// Copyright 2022 atframework

#include <iostream>
#include <memory>
#include <string>

#include "helloworld_generated.h"

int main(int argc, char** argv) {
  flatbuffers::FlatBufferBuilder fbb;
  helloworld::MessageT mutable_msg;

  mutable_msg.head = std::unique_ptr<helloworld::MessageHead>(new helloworld::MessageHead());
  mutable_msg.head->mutate_sequence(123);
  mutable_msg.head->mutate_timestamp(123000000);

  helloworld::HelloReplyT* reply = new helloworld::HelloReplyT();
  reply->message = "hello";
  mutable_msg.body.type = helloworld::MessageBody_hello_response;
  mutable_msg.body.value = reinterpret_cast<void*>(reply);

  auto msg = helloworld::CreateMessage(fbb, &mutable_msg);
  fbb.Finish(msg);

  const helloworld::Message* msg2 = helloworld::GetMessage(fbb.GetBufferPointer());
  std::cout << "head.sequence: " << msg2->head()->sequence() << std::endl;
  std::cout << "head.timestamp: " << msg2->head()->timestamp() << std::endl;
  std::cout << "body.hello_response.message: ";
  std::cout.write(msg2->body_as_hello_response()->message()->c_str(),
                  msg2->body_as_hello_response()->message()->size());
  std::cout << std::endl;
  return 0;
}
