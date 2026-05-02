// Cloudflare Worker entry.
//
// For visitors in mainland China (Cloudflare-detected country code "CN"),
// rewrite media URLs in HTML responses from `/uploads/...` to a jsDelivr
// URL that points at the same files in the GitHub repo. jsDelivr has
// in-country PoPs, so loading is fast and reliable from CN.
//
// Visitors anywhere else get the original HTML untouched and continue to
// fetch media from Cloudflare's own edge.

const JSDELIVR_BASE =
  'https://cdn.jsdelivr.net/gh/eiORQONrS/MyWebsite@main/public';

// Attributes that may carry a `/uploads/...` path we want to rewrite.
class AttrRewriter {
  constructor(attr) {
    this.attr = attr;
  }
  element(el) {
    const v = el.getAttribute(this.attr);
    if (v && v.startsWith('/uploads/')) {
      el.setAttribute(this.attr, JSDELIVR_BASE + v);
    }
  }
}

export default {
  async fetch(request, env) {
    // Hand the request to the Static Assets binding first.
    const response = await env.ASSETS.fetch(request);

    const country = request.cf && request.cf.country;
    const contentType = response.headers.get('content-type') || '';

    // Only rewrite HTML responses, and only for mainland-China visitors.
    if (country !== 'CN' || !contentType.includes('text/html')) {
      return response;
    }

    return new HTMLRewriter()
      .on('img', new AttrRewriter('src'))
      .on('video', new AttrRewriter('src'))
      .on('video', new AttrRewriter('poster'))
      .on('source', new AttrRewriter('src'))
      .on('link', new AttrRewriter('href'))
      .transform(response);
  },
};
