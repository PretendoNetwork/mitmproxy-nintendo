from mitmproxy import http, ctx


class PretendoAddon:
    def load(self, loader) -> None:
        loader.add_option(
            name="pretendo_redirect",
            typespec=bool,
            default=False,
            help="Redirect all requests from Nintendo to Pretendo",
        )

        loader.add_option(
            name="pretendo_http",
            typespec=bool,
            default=False,
            help="Sets Pretendo requests to HTTP",
        )

    def request(self, flow: http.HTTPFlow) -> None:
        if not ctx.options.pretendo_redirect:
            # This script should just be disabled
            return

        # The account server
        if "account.nintendo.net" in flow.request.host:
            flow.request.host = flow.request.host.replace("nintendo.net", "pretendo.cc")
            flow.request.port = 8080

            if ctx.options.pretendo_http:
                flow.request.scheme = "http"

        # The Grove eShop server
        if "geisha-wup.cdn.nintendo.net" in flow.request.host:
            flow.request.host = flow.request.host.replace(
                "geisha-wup.cdn.nintendo.net", "eshop.pretendo.cc"
            )
            flow.request.port = 8081

            if ctx.options.pretendo_http:
                flow.request.scheme = "http"

        # The olv-api Miiverse API server
        if (
            "discovery.olv.nintendo.net" in flow.request.host
            or "api.olv.nintendo.net" in flow.request.host
        ):
            flow.request.host = flow.request.host.replace("nintendo.net", "pretendo.cc")
            flow.request.port = 8082

            if ctx.options.pretendo_http:
                flow.request.scheme = "http"

        # The Juxtaposition Miiverse server
        elif "olv.nintendo.net" in flow.request.host:
            flow.request.host = flow.request.host.replace("nintendo.net", "pretendo.cc")
            flow.request.port = 8083

            if ctx.options.pretendo_http:
                flow.request.scheme = "http"


addons = [PretendoAddon()]
