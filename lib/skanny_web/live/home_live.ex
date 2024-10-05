defmodule SkannyWeb.HomeLive do
  use SkannyWeb, :live_view

  require Logger

  @allowed_file_types ~w(.jpg .jpeg .pdf)
  @max_entries 2
  @max_file_size_in_bytes 4_000_000
  # The chunk size in bytes to send when uploading. Defaults 64_000.
  @chunk_size_in_bytes 64_000

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:uploaded_files, [])
      |> allow_upload(:avatar,
        accept: @allowed_file_types,
        max_entries: @max_entries,
        max_file_size: @max_file_size_in_bytes,
        chunk_size: @chunk_size_in_bytes
      )

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    # No need to implement any validations for the upload input,
    # they are already handled by allow_upload/3.
    # Learn more -> https://hexdocs.pm/phoenix_live_view/uploads.html#entry-validation
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("save", _params, socket) do
    uploaded_files = consume_uploaded_entries(socket, :avatar, &save_to_disk(&1, &2))

    {flash_kind, flash_message} =
      case length(uploaded_files) do
        0 -> {:error, "Please select at least one file to proceed"}
        1 -> {:info, "Successfully uploaded 1 file"}
        n -> {:info, "Successfully uploaded #{n} files"}
      end

    socket =
      socket
      |> update(:uploaded_files, &(&1 ++ uploaded_files))
      |> put_flash(flash_kind, flash_message)

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <%!-- use phx-drop-target with the upload ref to enable file drag and drop --%>
    <div phx-drop-target={@uploads.avatar.ref} class="min-h-screen">
      <div class="border-2 border-red-500">
        <form id="upload-form" phx-submit="save" phx-change="validate">
          <.live_file_input upload={@uploads.avatar} class="border-4 border-green-500" />
          <button
            type="submit"
            disabled={any_errors?(@uploads.avatar)}
            class="disabled:border-8 border-red-500"
          >
            Upload
          </button>
        </form>
      </div>

      <div :for={err <- upload_errors(@uploads.avatar)}>
        <p class="border-4 border-cyan-500 alert alert-danger"><%= error_to_string(err) %></p>
      </div>

      <div><%= @uploaded_files %></div>

      <%!-- render each avatar entry --%>
      <div :for={entry <- @uploads.avatar.entries}>
        <article class="upload-entry">
          <figure>
            <.live_img_preview entry={entry} />
            <figcaption><%= entry.client_name %></figcaption>
          </figure>

          <progress value={entry.progress} max="100"><%= entry.progress %>%</progress>

          <button
            type="button"
            phx-click="cancel-upload"
            phx-value-ref={entry.ref}
            aria-label="cancel"
          >
            &times;
          </button>

          <div :for={err <- upload_errors(@uploads.avatar, entry)}>
            <p class="alert alert-danger"><%= error_to_string(err) %></p>
          </div>
        </article>
      </div>
    </div>
    """
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"

  defp save_to_disk(%{path: path}, _entry) do
    dest =
      :skanny
      |> Application.app_dir("priv/static/uploads")
      |> Path.join(Path.basename(path))

    # You will need to create `priv/static/uploads` for `File.cp!/2` to work.
    File.cp!(path, dest)
    {:ok, ~p"/uploads/#{Path.basename(path)}"}
  end

  defp any_errors?(%Phoenix.LiveView.UploadConfig{} = struct) do
    is_upload_ok? = upload_errors(struct) |> Enum.empty?()

    are_entries_ok? =
      struct.entries
      |> Enum.flat_map(fn e -> upload_errors(struct, e) end)
      |> Enum.empty?()

    !(is_upload_ok? and are_entries_ok?)
  end
end
