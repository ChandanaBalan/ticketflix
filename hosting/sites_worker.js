const PINIMG_HOST = 'i.pinimg.com';

function corsHeaders(headers) {
  const result = new Headers(headers);
  result.set('Access-Control-Allow-Origin', '*');
  result.set('Access-Control-Allow-Methods', 'GET, OPTIONS');
  result.set('Cache-Control', 'public, max-age=86400, s-maxage=604800');
  return result;
}

const worker = {
  async fetch(request, env) {
    const requestUrl = new URL(request.url);
    if (requestUrl.pathname === '/image-proxy') {
      if (request.method === 'OPTIONS') {
        return new Response(null, {status: 204, headers: corsHeaders()});
      }

      const source = requestUrl.searchParams.get('url');
      if (!source) {
        return new Response('Missing image URL.', {
          status: 400,
          headers: corsHeaders({'Content-Type': 'text/plain'}),
        });
      }

      let imageUrl;
      try {
        imageUrl = new URL(source);
      } catch {
        return new Response('Invalid image URL.', {
          status: 400,
          headers: corsHeaders({'Content-Type': 'text/plain'}),
        });
      }

      if (imageUrl.protocol !== 'https:' || imageUrl.hostname !== PINIMG_HOST) {
        return new Response('Image host is not allowed.', {
          status: 403,
          headers: corsHeaders({'Content-Type': 'text/plain'}),
        });
      }

      const imageResponse = await fetch(imageUrl);
      return new Response(imageResponse.body, {
        status: imageResponse.status,
        statusText: imageResponse.statusText,
        headers: corsHeaders(imageResponse.headers),
      });
    }

    const response = await env.ASSETS.fetch(request);
    if (response.status !== 404 || request.method !== 'GET') {
      return response;
    }

    const fallbackUrl = new URL('/index.html', request.url);
    return env.ASSETS.fetch(new Request(fallbackUrl, request));
  },
};

export default worker;
