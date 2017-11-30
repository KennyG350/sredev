defmodule Mix.Tasks.Ui.Gen do
  use Mix.Task

  @shortdoc "Create files for making ui components"
  @path "web/ui_components/ui"
  @file_paths ["html.eex", "scss", "ex"]

  def run([folder, name]) do
    folder_path = "#{@path}/#{folder}/#{name}"
    print "Creating file for: #{name}", :info

    case make_folder(folder_path) do
      :ok ->
        Enum.map @file_paths, &(make_file({folder, name}, "#{folder_path}", &1))
        print "Finished creating files for #{name}", :info

      _ ->
       print "Error happend when creating files for #{name}", :error
    end
  end

  defp make_folder(name) do
    name
    |> File.exists?
    |> make_folder(name)
  end

  defp make_folder(false, name), do: File.mkdir_p! name
  defp make_folder(true, _), do: :ok

  defp make_file(folder_name, path, suffix, content \\ "")
  defp make_file({_, name}, path, "scss", content), do: make_file "#{path}/_#{name |> String.replace("_", "-")}.scss", content
  defp make_file({folder, name}, path, "ex", _), do: make_file "#{path}/#{name}.ex", ex_file_content(folder, name)
  defp make_file({_, name}, path, suffix, content), do: make_file "#{path}/#{name}.#{suffix}", content
  defp make_file(path, content) do
    case File.exists? path do
      false ->
        File.write! path, content

      true ->
        :ok
    end
  end

  defp ex_file_content(folder, name) do
    """
    defmodule Sre.UI.#{folder |> String.capitalize |> Macro.camelize}.#{name |> String.capitalize |> Macro.camelize} do
      use Sre.Web, :ui_component

      @defaults []

      def render_template(opts \\\\ []) do
        render "#{name}.html", Keyword.merge(@defaults, opts)
      end
    end
    """
  end

  defp print(message, type) do
    type
    |> print
    |> Kernel.<>(message)
    |> IO.puts
  end
  defp print(:error), do: IO.ANSI.red
  defp print(:info), do: IO.ANSI.cyan

end
