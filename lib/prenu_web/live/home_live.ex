defmodule PrenuWeb.HomeLive do
  use PrenuWeb, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <%= for uploaded_file <- @uploaded_files do %>
      <img src={uploaded_file} />
    <% end %>

    <form id="upload-form" phx-submit="save" phx-change="validate">
      <.live_file_input upload={@uploads.file} />
      <button type="submit">Upload</button>
    </form>

    <section phx-drop-target={@uploads.file.ref}>
      <%!-- render each avatar entry --%>
      <%= for entry <- @uploads.file.entries do %>
        <article class="upload-entry">
          <div>
            <figcaption><%= entry.client_name %></figcaption>
          </div>

          <%!-- entry.progress will update automatically for in-flight entries --%>
          <progress value={entry.progress} max="100"><%= entry.progress %>%</progress>

          <%!-- a regular click event whose handler will invoke Phoenix.LiveView.cancel_upload/3 --%>
          <button
            type="button"
            phx-click="cancel-upload"
            phx-value-ref={entry.ref}
            aria-label="cancel"
          >
            &times;
          </button>

          <%!-- Phoenix.Component.upload_errors/2 returns a list of error atoms --%>
          <%= for err <- upload_errors(@uploads.file, entry) do %>
            <p class="alert alert-danger"><%= error_to_string(err) %></p>
          <% end %>
        </article>
      <% end %>

      <%!-- Phoenix.Component.upload_errors/1 returns a list of error atoms --%>
      <%= for err <- upload_errors(@uploads.file) do %>
        <p class="alert alert-danger"><%= error_to_string(err) %></p>
      <% end %>
    </section>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:file,
       accept: ~w(.avi .mov .mp3 .jpg),
       max_entries: 2,
       max_file_size: 12_000_000_000
     )}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :file, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :file, fn %{path: path}, _entry ->
        dest = Path.join([:code.priv_dir(:prenu), "static", "uploads", Path.basename(path)])
        # The `static/uploads` directory must exist for `File.cp!/2` to work.
        File.cp!(path, dest)

        {:ok, ~p"/uploads/#{Path.basename(dest)}"}
      end)

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
  end

  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  def error_to_string(:too_many_files), do: "You have selected too many files"
end
