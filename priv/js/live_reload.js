let reload = () => {
  window["top"].location.reload();
};

socket = new WebSocket("ws://" + location.host + "/live_reload/socket");
socket.addEventListener("message", (event) => {
  console.log(event)
  asset_type = event.data;
  setTimeout(function () {
    reload();
  }, interval);
});
