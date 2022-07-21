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
        if ctx.options.pretendo_redirect:
            if 'nintendo.net' in flow.request.pretty_host:
                flow.request.host_header = flow.request.pretty_host.replace('nintendo.net', 'pretendo.cc')

            if ctx.options.pretendo_http:
                flow.request.scheme = 'http'

addons = [PretendoAddon()]
