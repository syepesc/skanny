defmodule SkannyWeb.HomeLive do
  use SkannyWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div>HI FROM HOME</div>
    """
  end
end
