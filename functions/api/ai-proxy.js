const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Goog-Api-Key",
  "Cache-Control": "no-store",
};

function jsonResponse(payload, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      ...CORS_HEADERS,
      "Content-Type": "application/json; charset=utf-8",
    },
  });
}

function sanitizeForwardHeaders(input) {
  const safe = {};
  if (!input || typeof input !== "object") {
    return safe;
  }

  for (const [key, value] of Object.entries(input)) {
    if (typeof value !== "string" || value.trim() === "") {
      continue;
    }
    const lower = key.toLowerCase();
    if (
      lower === "authorization" ||
      lower === "content-type" ||
      lower === "x-goog-api-key"
    ) {
      safe[key] = value;
    }
  }
  if (!safe["Content-Type"] && !safe["content-type"]) {
    safe["Content-Type"] = "application/json";
  }
  return safe;
}

export async function onRequestOptions() {
  return new Response(null, {
    status: 204,
    headers: CORS_HEADERS,
  });
}

export async function onRequestPost(context) {
  try {
    const request = context.request;
    const payload = await request.json();
    const targetUrl = typeof payload.url === "string" ? payload.url.trim() : "";
    const body = payload.body ?? {};
    const headers = sanitizeForwardHeaders(payload.headers);

    if (!targetUrl || !targetUrl.startsWith("https://")) {
      return jsonResponse({ error: "Invalid target URL." }, 400);
    }

    const upstreamResponse = await fetch(targetUrl, {
      method: "POST",
      headers,
      body: JSON.stringify(body),
    });

    const resHeaders = new Headers(CORS_HEADERS);
    const contentType = upstreamResponse.headers.get("content-type");
    if (contentType) {
      resHeaders.set("Content-Type", contentType);
    }

    return new Response(await upstreamResponse.arrayBuffer(), {
      status: upstreamResponse.status,
      headers: resHeaders,
    });
  } catch (error) {
    return jsonResponse(
      {
        error: "Proxy request failed.",
        detail: String(error),
      },
      500,
    );
  }
}
