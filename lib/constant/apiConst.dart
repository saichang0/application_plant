class ApiConstants {
  // Local (emulator/localhost):
  // static const String graphQlUrl = 'http://localhost:5000/graphql';
  // static const String uploadUrl = 'http://localhost:5000/upload';

  // Local network (phone/other device on same WiFi):
  static const String graphQlUrl = 'http://10.239.186.208:5000/graphql';
  static const String uploadUrl = 'http://10.239.186.208:5000/upload';

  // Production (Cloudflare + Nginx + HTTPS on the api subdomain):
  // static const String graphQlUrl = 'https://api.gremk.online/graphql';
  // static const String uploadUrl = 'https://api.gremk.online/upload';
}
