defmodule Identicon do
  @moduledoc """
  Documentation for `Identicon`.
  """

  @doc """
  x

  ## Examples

      iex> Identicon.x
      "x"

  """
  def x do
  "x"
  end

  @doc """
  In this function will be the all methods and exec together and transform a String in a image.

  """
  def main(input) do
    input
    |> hash_input # When finish, run the next, the return becomes a parameter of the next function
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)

  end

  @doc """
  
  Return a hash(md5) of a string.

  ## Examplepick_color(image)

      iex> Identicon.hash_input("a")
      [12, 193, 117, 185, 192, 241, 182, 168, 49, 195, 153, 226, 105, 119, 38, 97]

  """
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  @doc """
  Pick the first 3 numbers of hex and transform in RGB

  ## Examples

      iex> Identicon.hash_input("a")
      [12, 193, 117, 185, 192, 241, 182, 168, 49, 195, 153, 226, 105, 119, 38, 97]
      iex> Identicon.pick_color(image)
      [12, 193, 117]

  """
  def pick_color(%Identicon.Image{hex: [ red, green, blue | _tail ] } = image) do
    # %Identicon.Image{hex: hex_list} = image
    # [ red, green, blue | _tail ] = hex_list # | _tail --> Ignore the other datas, if no has a "| _tail" no works, because the pattern matching accepts only the same length of values on the list.  end

    %Identicon.Image{image | color: { red, green, blue }} # Create a new struct, first param is the reference data and second is the id of defstruct var, in which, the value of RGB is asign.
  end

@doc """
  build_grid(image)

  ## Examples

      iex> Identicon.build_grid(image)
      "x"

  """
  def build_grid(%Identicon.Image{hex: hex} = image) do
  grid = hex # Pick this and pass to the first method of the pipes
    |> Enum.chunk(3) # Transform one array in a array with arrays with 3 numbers only, if rest some value its discarded.
    |> Enum.map(&mirror_row/1) # To pass functions in the parameter you have to add "&" on the start and "/1" in end, "/argument" --> MAP = To every data in this array, run this function, map returns one array with the treated data.
    |> List.flatten # All values in one list. Array is List
    |> Enum.with_index

  %Identicon.Image{image | grid: grid}
  end

  def mirror_row(row) do 
    [ first, second | _tail ] = row

    row ++ [ second, first] # Append list(++).
  end

     @doc """
  filter_odd_squares()

  ## Examples

      iex> Identicon.filter_odd_squares()
      ""

  """

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    # Enum.filter( grid, fn(square) -> end)

    grid = Enum.filter grid, fn({code, _index}) -> 
      rem(code, 2) == 0 # rem(20, 2) = 0, is the rest
    end

    %Identicon.Image{image | grid: grid}
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({ _code, index }) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index,5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image,start,stop,fill)
    end

    :egd.render(image)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end

end 
