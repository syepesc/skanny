defmodule SkannyWeb.HomeLive do
  use SkannyWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-8 p-8 justify-center items-center h-full">
      <.link
        navigate={~p"/upload-to-disk"}
        class="cursor-pointer rounded-lg p-4 border-4 w-full max-w-2xl border-gray-300 hover:bg-gray-100"
      >
        <div>
          <p class="text-lg font-bold">Upload files locally to disk -></p>
          <p>The files will be uploaded under "/skanny/priv/static/uploads/..."</p>
        </div>
      </.link>

      <.link
        navigate={~p"/upload-to-s3"}
        class="cursor-pointer rounded-lg p-4 w-full max-w-2xl border-4 border-gray-300 hover:bg-gray-100"
      >
        <div>
          <p class="text-lg font-bold">Upload files to S3 -></p>
          <p>
            Make sure you setup your AWS resources before trying to upload to S3, read "How to configure AWS S3 uploads?" section in the README.
          </p>
        </div>
      </.link>
    </div>
    """
  end
end
