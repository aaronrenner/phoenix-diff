defmodule PhxDiff.Diffs.Config do
  @moduledoc """
  Configuration for PhxDiff
  """

  defstruct [:app_repo_path, :app_generator_workspace_path, :earthly_path]

  @type t :: %__MODULE__{
          app_repo_path: String.t(),
          app_generator_workspace_path: String.t(),
          earthly_path: String.t()
        }

  @type new_opt ::
          {:app_repo_path, String.t()}
          | {:app_generator_workspace_path, String.t()}
          | {:earthly_path, String.t()}

  @doc """
  Builds a new configuration, overriding the default values
  """
  @spec new([new_opt]) :: t
  def new(opts \\ []) do
    attrs =
      Enum.into(
        opts,
        %{
          app_repo_path: "data/sample-app",
          app_generator_workspace_path: "tmp",
          earthly_path: System.get_env("PHX_DIFF_EARTHLY_PATH", "earthly")
        }
      )

    struct!(__MODULE__, attrs)
  end
end
