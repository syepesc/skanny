defmodule SkannyWeb.UploadToDiskLive do
  use SkannyWeb, :live_view

  alias Skanny.CommonUtils

  require Logger

  @allowed_file_types ~w(.jpg .jpeg .pdf)
  @max_file_size_in_bytes 100_000
  @max_entries 2
  # The chunk size in bytes to send when uploading. Defaults 64_000.
  @chunk_size_in_bytes 20

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:uploaded_files, [])
      |> assign(:allowed_file_types, @allowed_file_types)
      |> allow_upload(:jpg_jpeg_pdf,
        accept: @allowed_file_types,
        max_entries: @max_entries,
        max_file_size: @max_file_size_in_bytes,
        chunk_size: @chunk_size_in_bytes
      )

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("validate-files", _params, socket) do
    # No need to implement any validations for the upload input,
    # they are already handled by allow_upload/3.
    # Learn more -> https://hexdocs.pm/phoenix_live_view/uploads.html#entry-validation
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("upload-files", _params, socket) do
    uploaded_files = consume_uploaded_entries(socket, :jpg_jpeg_pdf, &save_to_disk(&1, &2))

    socket =
      if Enum.empty?(uploaded_files) do
        # do nothing
        socket
      else
        # update socket and send flash message
        {flash_kind, flash_message} =
          case length(uploaded_files) do
            1 -> {:info, "Successfully uploaded 1 file"}
            n -> {:info, "Successfully uploaded #{n} files"}
          end

        socket
        |> update(:uploaded_files, &(&1 ++ uploaded_files))
        |> put_flash(flash_kind, flash_message)
      end

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :jpg_jpeg_pdf, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("delete-uploaded-file", %{"ref" => ref}, socket) do
    # TODO: remove from disk
    file_to_remove = Enum.filter(socket.assigns.uploaded_files, fn f -> f.ref == ref end)
    {:noreply, update(socket, :uploaded_files, &(&1 -- file_to_remove))}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <%!-- use phx-drop-target with the upload ref to enable file drag and drop --%>
    <div
      id="drop-area"
      phx-hook="DragAndDropHook"
      phx-drop-target={@uploads.jpg_jpeg_pdf.ref}
      class="drop-area"
    >
      <div id="page-content" class="flex flex-col gap-8 p-8 w-full max-w-4xl">
        <%!-- welcome paragraph --%>
        <h1 id="welcome-paragraph" class="text-center">
          <%= "Choose or Drop your documents or images here to upload them locally in disk (supported files: #{@allowed_file_types})." %>
        </h1>

        <%!-- choose files and upload button --%>
        <form
          id="upload-form"
          phx-submit="upload-files"
          phx-change="validate-files"
          class="flex justify-center gap-4"
        >
          <label
            for={@uploads.jpg_jpeg_pdf.ref}
            class="cursor-pointer rounded-lg p-2 w-full text-center border-4 border-gray-300 hover:bg-gray-100"
          >
            Choose Files
          </label>
          <.live_file_input
            id="choose-file-button"
            upload={@uploads.jpg_jpeg_pdf}
            disabled={false}
            class="hidden"
          />
          <.button
            id="upload-button"
            type="submit"
            disabled={any_errors?(@uploads.jpg_jpeg_pdf)}
            class="disabled:cursor-not-allowed"
          >
            Upload
          </.button>
        </form>

        <%!-- render general errors like: "you have selected many files" --%>
        <div
          :for={err <- upload_errors(@uploads.jpg_jpeg_pdf)}
          id="general-errors"
          class="rounded-lg p-2 border-2 border-red-500 text-center text-red-500 hover:bg-red-100"
        >
          <%= error_to_string(err) %>
        </div>

        <%!-- files to upload list --%>
        <div
          :if={not Enum.empty?(@uploads.jpg_jpeg_pdf.entries)}
          id="files-to-upload"
          class="flex flex-col gap-2"
        >
          <h2>Files to Upload</h2>

          <%!-- render file --%>
          <div
            :for={file <- @uploads.jpg_jpeg_pdf.entries}
            id={"file-#{file.ref}"}
            class={[
              "flex flex-col rounded-lg py-2 px-4 gap-2 border-2",
              if(file.valid?,
                do: "border-green-500 hover:bg-green-100",
                else: "border-red-500 hover:bg-red-100"
              )
            ]}
          >
            <%!-- render error specific to each file --%>
            <div :for={err <- upload_errors(@uploads.jpg_jpeg_pdf, file)} class="text-red-500">
              <%= error_to_string(err) %>
            </div>

            <div class="flex gap-4 items-center">
              <div class="cursor-pointer">
                <.icon phx-click="cancel-upload" phx-value-ref={file.ref} name="hero-trash" />
              </div>
              <div :if={file.progress > 0}><.icon class="animate-spin" name="hero-arrow-path" /></div>
              <div :if={file.progress > 0}><%= "#{file.progress}%" %></div>
              <div class={["break-all", if(not file.valid?, do: "text-red-500")]}>
                <%= file.client_name %>
              </div>
            </div>
          </div>
        </div>

        <%!-- uploaded files list
              this exist because LiveView Uploads remove uploaded files from @uploads when
              calling `consume_uploaded_entries()`, however, we want to keep the files after uploaded to show them in UI
        --%>
        <div :if={not Enum.empty?(@uploaded_files)} id="uploaded-files" class="flex flex-col gap-2">
          <h2>Uploaded Files</h2>
          <%!-- render file --%>
          <div
            :for={file <- @uploaded_files}
            id={"uploaded-file-#{file.ref}"}
            class={[
              "flex items-center rounded-lg py-2 px-4 gap-2 border-2",
              if(file.valid?,
                do: "border-green-500 hover:bg-green-100",
                else: "border-red-500 hover:bg-red-100"
              )
            ]}
          >
            <div class="cursor-pointer">
              <.icon phx-click="delete-uploaded-file" phx-value-ref={file.ref} name="hero-trash" />
            </div>
            <div><.icon class="text-green-500" name="hero-check" /></div>
            <div class="break-all"><%= file.client_name %></div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp save_to_disk(%{path: path}, file) do
    file_name = "#{CommonUtils.generate_random_id()}--#{file.client_name}"

    dest =
      :skanny
      |> Application.app_dir("priv/static/uploads")
      |> Path.join(Path.basename(file_name))

    # You will need to create `priv/static/uploads` for `File.cp!/2` to work.
    File.cp!(path, dest)
    {:ok, file}
  end

  defp error_to_string(:too_large), do: "File is too large"

  defp error_to_string(:not_accepted), do: "Unsupported file type"

  defp error_to_string(:too_many_files),
    do: "Too many files, max #{@max_entries} files per upload"

  defp any_errors?(%Phoenix.LiveView.UploadConfig{} = struct) do
    # is recommended to use these predefine functions to get errors instead of accessing the struct
    is_upload_ok? = struct |> upload_errors() |> Enum.empty?()

    are_entries_ok? =
      struct.entries
      |> Enum.flat_map(fn e -> upload_errors(struct, e) end)
      |> Enum.empty?()

    Enum.empty?(struct.entries) or !(is_upload_ok? and are_entries_ok?)
  end
end

# TODO: disabled choose file button while uploading file is in progress, check -> https://hexdocs.pm/phoenix_live_view/bindings.html
# TODO: add preview button for every entry
# TODO: add error on duplicate files rigth after user drop the files in the UI
