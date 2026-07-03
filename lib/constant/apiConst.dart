class ApiConstants {
  // Local development (your laptop on the same WiFi):
  // static const String graphQlUrl = 'http://10.41.207.208:5000/graphql';

  // Production (Cloudflare + Nginx + HTTPS on the api subdomain):
  static const String graphQlUrl = 'https://api.gremk.online/graphql';
  static const String uploadUrl = 'https://api.gremk.online/upload';
}
