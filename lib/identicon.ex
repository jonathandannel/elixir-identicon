defmodule Identicon do

  def main(input) do
    input 
    |> hash_string
    |> set_color
    |> create_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end
  
  def hash_string(string) do
    hex = :crypto.hash(:md5, string)
    |> :binary.bin_to_list
    # Store list of binary values for hash in Image struct as `hex`
    %Identicon.Image{hex: hex}
  end

  # First 3 items in hex list can be used to generate a color (R, G, B)
  def set_color(%Identicon.Image{hex: [r, g, b | _rest ]} = image) do
     %Identicon.Image{image | color: { r, g, b }}
  end

  # Split the data into groups of 3, map over each row to add the mirrored elements
  def create_grid(%Identicon.Image{hex: hex} = image) do
    grid = 
      hex 
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image | grid: grid }
  end

  # Add first two indices (reversed) to each row
  def mirror_row([first, second, _tail] = row) do
    row ++ [second, first]
  end

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    filtered_grid = Enum.filter grid, fn({hex, _index}) -> 
      rem(hex, 2) == 0
    end
   %Identicon.Image{image | grid: filtered_grid}
  end

  # Generate a pixel representation of our grid for drawing our image
  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_hex, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50
      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}
      {top_left, bottom_right}
    end
    %Identicon.Image{image | pixel_map: pixel_map}
  end

  # Render image
  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)
    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end
    :egd.render(image)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end
end
