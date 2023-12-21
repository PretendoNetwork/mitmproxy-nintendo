from mitmproxy import http, ctx


class PretendoAddon:
    def load(self, loader) -> None:
        loader.add_option(
            name="pretendo_redirect",
            typespec=bool,
            default=True,
            help="Redirect all requests from Nintendo to Pretendo",
        )

        loader.add_option(
            name="pretendo_host",
            typespec=str,
            default="",
            help="Host to send Pretendo requests to (keeps the original host in the Host header)",
        )

        loader.add_option(
            name="pretendo_host_port",
            typespec=int,
            default=80,
            help="Port to send Pretendo requests to (only applies if pretendo_host is set)",
        )

        loader.add_option(
            name="pretendo_http",
            typespec=bool,
            default=False,
            help="Sets Pretendo requests to HTTP (only applies if pretendo_host is set)",
        )

    def request(self, flow: http.HTTPFlow) -> None:
        if ctx.options.pretendo_redirect:
            if "nintendo.net" in flow.request.pretty_host:
                flow.request.host = flow.request.pretty_host.replace(
                    "nintendo.net", "pretendo.cc"
                )
            elif "nintendowifi.net" in flow.request.pretty_host:
                flow.request.host = flow.request.pretty_host.replace(
                    "nintendowifi.net", "pretendo.cc"
                )

            if ctx.options.pretendo_host and (
                "pretendo.cc" in flow.request.pretty_host
                or "pretendo.network" in flow.request.pretty_host
                or "pretendo-cdn.b-cdn.net" in flow.request.pretty_host
            ):
                original_host = flow.request.host_header
                flow.request.host = ctx.options.pretendo_host
                flow.request.port = ctx.options.pretendo_host_port
                flow.request.host_header = original_host

                if ctx.options.pretendo_http:
                    flow.request.scheme = "http"


addons = [PretendoAddon()]
