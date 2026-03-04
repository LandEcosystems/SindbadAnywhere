using AWS

struct AnonymousGCS <:AbstractAWSConfig end
struct NoCredentials end
AWS.region(aws::AnonymousGCS) = "" # No region
AWS.credentials(aws::AnonymousGCS) = NoCredentials() # No credentials
AWS.check_credentials(c::NoCredentials) = c # Skip credentials check
AWS.sign!(aws::AnonymousGCS, ::AWS.Request) = nothing # Don't sign request
function AWS.generate_service_url(aws::AnonymousGCS, service::String, resource::String)
    service == "s3" || throw(ArgumentError("Can only handle s3 requests to GCS"))
    awsurl =  string("https://s3.bgc-jena.mpg.de:9000/", resource)
    @show awsurl
    return awsurl
end
AWS.global_aws_config(AnonymousGCS())