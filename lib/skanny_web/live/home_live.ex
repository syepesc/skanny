defmodule SkannyWeb.HomeLive do
  use SkannyWeb, :live_view

  require Logger

  @allowed_file_types ~w(.jpg .jpeg .pdf)
  @kilo_bytes 1000
  @max_file_size_in_bytes 100 * @kilo_bytes
  @max_entries 2
  # The chunk size in bytes to send when uploading. Defaults 64_000.
  @chunk_size_in_bytes 50

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:uploaded_files, [])
      |> assign(:allowed_file_types, @allowed_file_types)
      |> allow_upload(:file,
        accept: @allowed_file_types,
        max_entries: @max_entries,
        max_file_size: @max_file_size_in_bytes,
        chunk_size: @chunk_size_in_bytes
      )

    {:ok, socket, layout: false}
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
    uploaded_files = consume_uploaded_entries(socket, :file, &save_to_disk(&1, &2))

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
    {:noreply, cancel_upload(socket, :file, ref)}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <%!-- use phx-drop-target with the upload ref to enable file drag and drop --%>
    <div
      id="drop-area"
      phx-hook="DragAndDropHook"
      phx-drop-target={@uploads.file.ref}
      class="drop-area"
    >
      <div id="page-container" class="flex flex-col m-auto gap-8 sm:p-8 p-4 max-w-4xl">
        <%!-- welcome paragraph --%>
        <div id="welcome-paragraph" class="text-center">
          <%= "Choose or Drop your documents or images here to extract id data from them (supported files: #{@allowed_file_types})." %>
        </div>

        <%!-- choose files and upload button --%>
        <form
          id="upload-form"
          phx-submit="save"
          phx-change="validate"
          class="flex justify-center gap-4"
        >
          <label
            for={@uploads.file.ref}
            class="cursor-pointer rounded-lg p-2 w-full text-center border-4 hover:bg-gray-500"
          >
            Choose Files
          </label>
          <.live_file_input id="choose-file-button" upload={@uploads.file} class="hidden" />
          <.button id="upload-button" type="submit" disabled={any_errors?(@uploads.file)}>
            Upload
          </.button>
        </form>

        <div id="files" class="flex flex-col gap-2">
          <%!-- render general errors like: "you have selected many files" --%>
          <div
            :for={err <- upload_errors(@uploads.file)}
            class="w-full rounded-lg p-2 border-2 border-red-500 text-center"
          >
            <%= error_to_string(err) %>
          </div>

          <%!-- render each file --%>
          <div
            :for={file <- @uploads.file.entries}
            id={"file-#{file.ref}"}
            class="flex flex-col w-full rounded-lg p-2 border-4"
          >
            <%!-- render each file error specific to file --%>
            <div :for={err <- upload_errors(@uploads.file, file)} class="text-red-500 p-2">
              <%= error_to_string(err) %>
            </div>

            <div class="flex gap-4 items-center p-2">
              <div class="cursor-pointer">
                <.icon phx-click="cancel-upload" phx-value-ref={file.ref} name="hero-trash" />
              </div>
              <div class="text-pretty truncate"><%= file.client_name %></div>
              <%!-- <progress value={file.progress} max="100"></progress> --%>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp error_to_string(:too_large), do: "File is too large"

  defp error_to_string(:not_accepted), do: "Unsupported file type"

  defp error_to_string(:too_many_files),
    do: "You have selected too many files, maximum is #{@max_entries} files per upload"

  defp save_to_disk(%{path: path}, _file) do
    dest =
      :skanny
      |> Application.app_dir("priv/static/uploads")
      |> Path.join(Path.basename(path))

    # You will need to create `priv/static/uploads` for `File.cp!/2` to work.
    File.cp!(path, dest)
    {:ok, ~p"/uploads/#{Path.basename(path)}"}
  end

  defp any_errors?(%Phoenix.LiveView.UploadConfig{} = struct) do
    is_upload_ok? = struct |> upload_errors() |> Enum.empty?()

    are_entries_ok? =
      struct.entries
      |> Enum.flat_map(fn e -> upload_errors(struct, e) end)
      |> Enum.empty?()

    !(is_upload_ok? and are_entries_ok?)
  end
end
