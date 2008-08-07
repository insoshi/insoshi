# NewRelic Agent instrumentation for WebServices

# Note Action Web Service is removed from default package in rails 2.0
if defined? ActionWebService

# instrumentation for Web Service martialing - XML RPC
class ActionWebService::Protocol::XmlRpc::XmlRpcProtocol
  add_method_tracer :decode_request, "WebService/Xml Rpc/XML Decode"
  add_method_tracer :encode_request, "WebService/Xml Rpc/XML Encode"
  add_method_tracer :decode_response, "WebService/Xml Rpc/XML Decode"
  add_method_tracer :encode_response, "WebService/Xml Rpc/XML Encode"
end

# instrumentation for Web Service martialing - Soap
class ActionWebService::Protocol::Soap::SoapProtocol
  add_method_tracer :decode_request, "WebService/Soap/XML Decode"
  add_method_tracer :encode_request, "WebService/Soap/XML Encode"
  add_method_tracer :decode_response, "WebService/Soap/XML Decode"
  add_method_tracer :encode_response, "WebService/Soap/XML Encode"
end


end
