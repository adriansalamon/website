defmodule Website.LiveReload.LiveReloadComponent do
  use Phoenix.Component

  def live_reload_component(assigns) do
    ~H"""
    <script defer>
      function connect() {
        try {
          window.socket = new WebSocket('ws://' + location.host + '/live_reload/socket');

          window.socket.onmessage = function(e) {
            if (e.data === "reload") {
              location.reload();
            }
          }

          window.socket.onopen = () => {
            waitForConnection(() => window.socket.send("subscribe"), 300);
          };

          window.socket.onclose = () => {
            setTimeout(() => connect(), 500);
          };

          function waitForConnection(callback, interval) {
            console.log("Waiting for connection!")
            if (window.socket.readyState === 1) {
              callback();
            } else {
              console.log("setting a timeout")
              setTimeout(() => waitForConnection(callback, interval), interval);
            }
          }
        } catch (e) {
          console.log(e)
          setTimeout(() => connect(), 500);
        }
      }

      connect();
    </script>
    """
  end
end
