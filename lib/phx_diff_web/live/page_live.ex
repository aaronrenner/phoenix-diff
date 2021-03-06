defmodule PhxDiffWeb.PageLive do
  @moduledoc false
  use PhxDiffWeb, :live_view

  alias Ecto.Changeset
  alias PhxDiff.Diffs
  alias PhxDiff.Diffs.AppSpecification
  alias PhxDiffWeb.PageLive.DiffSelection

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:no_changes?, false)
     |> assign(:all_versions, Diffs.all_versions())
     |> assign(:diff_selection, %DiffSelection{})}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    case validate_form(socket.assigns.diff_selection, params) do
      {:ok, diff_selection} ->
        %DiffSelection{source: source, target: target} = diff_selection
        source_app_spec = Diffs.fetch_default_app_specification!(source)
        target_app_spec = Diffs.fetch_default_app_specification!(target)

        {:ok, diff} = Diffs.get_diff(source_app_spec, target_app_spec)

        {:noreply,
         socket
         |> assign(:diff_selection, diff_selection)
         |> assign(:changeset, DiffSelection.changeset(diff_selection))
         |> assign(:page_title, page_title(source_app_spec, target_app_spec))
         |> assign(:no_changes?, diff == "")
         |> assign(:diff, diff)
         |> assign(:source_version, source)
         |> assign(:source_arguments, arguments_string(source_app_spec))
         |> assign(:target_version, target)
         |> assign(:target_arguments, arguments_string(target_app_spec))}

      {:error, _changeset} ->
        {:noreply,
         push_patch(socket,
           to:
             Routes.page_path(socket, :index,
               source: Diffs.previous_release_version(),
               target: Diffs.latest_version()
             )
         )}
    end
  end

  @impl true
  def handle_event("diff-changed", %{"diff_selection" => params}, socket) do
    case validate_form(socket.assigns.diff_selection, params) do
      {:ok, %{source: source, target: target}} ->
        {:noreply,
         push_patch(socket,
           to:
             Routes.page_path(socket, :index,
               source: source,
               target: target
             )
         )}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp validate_form(%DiffSelection{} = diff_selection, params) do
    diff_selection
    |> DiffSelection.changeset(params)
    |> Changeset.apply_action(:lookup)
  end

  defp page_title(%AppSpecification{} = source, %AppSpecification{} = target) do
    "v#{source.phoenix_version} to v#{target.phoenix_version}"
  end

  defp arguments_string(%AppSpecification{phx_new_arguments: []}), do: nil

  defp arguments_string(%AppSpecification{phx_new_arguments: args}) do
    Enum.join(args, " ")
  end
end
