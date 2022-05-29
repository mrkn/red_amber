# DataFrame

Class `RedAmber::DataFrame` represents 2D-data. `DataFrame` consists with:
- A collection of data which have same data type within. We call it `Vector`.
- A label is attached to `Vector`. We call it `key`.
- A `Vector` and associated `key` is grouped as a `variable`.
- `variable`s with same vector length are aligned and arranged to be a `DaTaFrame`.
- Each `Vector` in a `DataFrame` contains a set of relating data at same position. We call it `observation`.

![dataframe model image](doc/../image/dataframe_model.png)

## Constructors and saving

### `new` from a columnar Hash

  ```ruby
  RedAmber::DataFrame.new(x: [1, 2, 3])
  ```

### `new` from a schema (by Hash) and rows (by Array)

  ```ruby
  RedAmber::DataFrame.new({:x=>:uint8}, [[1], [2], [3]])
  ```

### `new` from an Arrow::Table


  ```ruby
  table = Arrow::Table.new(x: [1, 2, 3])
  RedAmber::DataFrame.new(table)
  ```

### `new` from a Rover::DataFrame


  ```ruby
  rover = Rover::DataFrame.new(x: [1, 2, 3])
  RedAmber::DataFrame.new(rover)
  ```

### `load` (class method)

- from a `.arrow`, `.arrows`, `.csv`, `.csv.gz` or `.tsv` file
       
  ```ruby
  RedAmber::DataFrame.load("test/entity/with_header.csv")
  ```

- from a string buffer

- from a URI

  ```ruby
  uri = URI("https://github.com/heronshoes/red_amber/blob/master/test/entity/with_header.csv")
  RedAmber::DataFrame.load(uri)
  ```

- from a Parquet file

  ```ruby
  dataframe = RedAmber::DataFrame.load("file.parquet")
  ```

### `save` (instance method)

- to a `.arrow`, `.arrows`, `.csv`, `.csv.gz` or `.tsv` file

- to a string buffer

- to a URI

- to a Parquet file

  ```ruby
  dataframe.save("file.parquet")
  ```

## Properties

### `table`

- Reader of Arrow::Table object inside.

### `size`, `n_obs`, `n_rows`
  
- Returns size of Vector (num of observations).
 
### `n_keys`, `n_vars`, `n_cols`,
  
- Returns num of keys (num of variables).
 
### `shape`
 
- Returns shape in an Array[n_rows, n_cols].
 
### `keys`, `var_names`, `column_names`
  
- Returns key names in an Array.

### `types`
  
- Returns types of vectors in an Array of Symbols.

### `data_types`

- Returns types of vector in an Array of `Arrow::DataType`.

### `vectors`

- Returns an Array of Vectors.

### `indexes`, `indices`

- Returns all indexes in a Range.

### `to_h`

- Returns column-oriented data in a Hash.

### `to_a`, `raw_records`

- Returns an array of row-oriented data without header.
  
  If you need a column-oriented full array, use `.to_h.to_a`

### `schema`

- Returns column name and data type in a Hash.

### `==`
 
### `empty?`

## Output

### `to_s`

### `summary`, `describe` (not implemented)

### `to_rover`

- Returns a `Rover::DataFrame`.

### `tdr(limit = 10, tally: 5, elements: 5)`

  - Shows some information about self in a transposed style.
  - `tdr_str` returns same info as a String.

  ```ruby
  require 'red_amber'
  require 'datasets-arrow'

  penguins = Datasets::Penguins.new.to_arrow
  RedAmber::DataFrame.new(penguins).tdr
  # =>
  RedAmber::DataFrame : 344 x 8 Vectors
  Vectors : 5 numeric, 3 strings
  # key                type   level data_preview
  1 :species           string     3 {"Adelie"=>152, "Chinstrap"=>68, "Gentoo"=>124}
  2 :island            string     3 {"Torgersen"=>52, "Biscoe"=>168, "Dream"=>124}
  3 :bill_length_mm    double   165 [39.1, 39.5, 40.3, nil, 36.7, ... ], 2 nils
  4 :bill_depth_mm     double    81 [18.7, 17.4, 18.0, nil, 19.3, ... ], 2 nils
  5 :flipper_length_mm uint8     56 [181, 186, 195, nil, 193, ... ], 2 nils
  6 :body_mass_g       uint16    95 [3750, 3800, 3250, nil, 3450, ... ], 2 nils
  7 :sex               string     3 {"male"=>168, "female"=>165, nil=>11}
  8 :year              uint16     3 {2007=>110, 2008=>114, 2009=>120}
  ```

  - limit: limits variable number to show. Default value is 10.
  - tally: max level to use tally mode.
  - elements: max num of element to show values in each observations.

### `inspect`

- Returns the information of self as `tdr(3)`, and also shows object id.

  ```ruby
  puts penguins.inspect
  # =>
  #<RedAmber::DataFrame : 344 x 8 Vectors, 0x000000000000f0b4>
  Vectors : 5 numeric, 3 strings
  # key                type   level data_preview
  1 :species           string     3 {"Adelie"=>152, "Chinstrap"=>68, "Gentoo"=>124}
  2 :island            string     3 {"Torgersen"=>52, "Biscoe"=>168, "Dream"=>124}
  3 :bill_length_mm    double   165 [39.1, 39.5, 40.3, nil, 36.7, ... ], 2 nils
   ... 5 more Vectors ...
  ```

## Selecting

### Select variables (columns in a table) by `[]` as `[key]`, `[keys]`, `[keys[index]]`
- Key in a Symbol: `df[:symbol]`
- Key in a String: `df["string"]`
- Keys in an Array: `df[:symbol1, "string", :symbol2]`
- Keys by indeces: `df[df.keys[0]`, `df[df.keys[1,2]]`, `df[df.keys[1..]]`

  Key indeces can be used via `keys[i]` because numbers are used to select observations (rows).

- Keys by a Range:

  If keys are able to represent by Range, it can be included in the arguments. See a example below.

- You can exchange the order of variables (columns).
 
  ```ruby
  hash = {a: [1, 2, 3], b: %w[A B C], c: [1.0, 2, 3]}
  df = RedAmber::DataFrame.new(hash)
  df[:b..:c, "a"]
  # =>
  #<RedAmber::DataFrame : 3 x 3 Vectors, 0x000000000000b02c>
  Vectors : 2 numeric, 1 string            
  # key type   level data_preview         
  1 :b  string     3 ["A", "B", "C"]      
  2 :c  double     3 [1.0, 2.0, 3.0]      
  3 :a  uint8      3 [1, 2, 3]
  ```

  If `#[]` represents single variable (column), it returns a Vector object.

  ```ruby
  df[:a]
  # =>
  #<RedAmber::Vector(:uint8, size=3):0x000000000000f140>
  [1, 2, 3]
  ```
  This may be useful to use in a block of DataFrame manipulations.

### Select observations (rows in a table) by `[]` as `[index]`, `[range]`, `[array]`

- Select a obs. by index: `df[0]`
- Select obs. by indeces in a Range: `df[1..2]`

  An end-less or a begin-less Range can be used to represent indeces.

- Select obs. by indeces in an Array: `df[1, 2]`
- Mixed case: `df[2, 0..]`

  ```ruby
  hash = {a: [1, 2, 3], b: %w[A B C], c: [1.0, 2, 3]}
  df = RedAmber::DataFrame.new(hash)
  df[:b..:c, "a"].tdr(tally_level: 0)
  # =>
  RedAmber::DataFrame : 4 x 3 Vectors
  Vectors : 2 numeric, 1 string
  # key type   level data_preview
  1 :a  uint8      3 [3, 1, 2, 3]
  2 :b  string     3 ["C", "A", "B", "C"]
  3 :c  double     3 [3.0, 1.0, 2.0, 3.0]
  ```

- Select obs. by a boolean Array or a boolean RedAmber::Vector at same size as self.

  It returns a sub dataframe with observations at boolean is true.

    ```ruby
    # with the same dataframe `df` above
    df[true, false, nil] # or
    df[[true, false, nil]] # or
    df[RedAmber::Vector.new([true, false, nil])]
    # =>
    #<RedAmber::DataFrame : 1 x 3 Vectors, 0x000000000000f1a4>
    Vectors : 2 numeric, 1 string
    # key type   level data_preview
    1 :a  uint8      1 [1]
    2 :b  string     1 ["A"]
    3 :c  double     1 [1.0]
    ```

### Select rows from top or bottom

  `head(n=5)`, `tail(n=5)`, `first(n=1)`, `last(n=1)`

## Sub DataFrame manipulations

### `pick`

  Pick up some variables (columns) to create a sub DataFrame.

  ![pick method image](doc/../image/dataframe/pick.png)

- Keys as arguments

  `pick(keys)` accepts keys as arguments in an Array.

    ```ruby
    penguins.pick(:species, :bill_length_mm)
    # =>
    #<RedAmber::DataFrame : 344 x 2 Vectors, 0x000000000000f924>
    Vectors : 1 numeric, 1 string
    # key             type   level data_preview
    1 :species        string     3 {"Adelie"=>152, "Chinstrap"=>68, "Gentoo"=>124}
    2 :bill_length_mm double   165 [39.1, 39.5, 40.3, nil, 36.7, ... ], 2 nils
    ```

- Booleans as a argument

  `pick(booleans)` accepts booleans as a argument in an Array. Booleans must be same length as `n_keys`.

    ```ruby
    penguins.pick(penguins.types.map { |type| type == :string })
    # =>
    #<RedAmber::DataFrame : 344 x 3 Vectors, 0x000000000000f938>
    Vectors : 3 strings
    # key      type   level data_preview
    1 :species string     3 {"Adelie"=>152, "Chinstrap"=>68, "Gentoo"=>124}
    2 :island  string     3 {"Torgersen"=>52, "Biscoe"=>168, "Dream"=>124}
    3 :sex     string     3 {"male"=>168, "female"=>165, ""=>11}
    ```

 - Keys or booleans by a block

    `pick {block}` is also acceptable. We can't use both arguments and a block at a same time. The block should return keys, or a boolean Array with a same length as `n_keys`. Block is called in the context of self.

    ```ruby
    penguins.pick { keys.map { |key| key.end_with?('mm') } }
    # =>
    #<RedAmber::DataFrame : 344 x 3 Vectors, 0x000000000000f1cc>
    Vectors : 3 numeric
    # key                type   level data_preview
    1 :bill_length_mm    double   165 [39.1, 39.5, 40.3, nil, 36.7, ... ], 2 nils
    2 :bill_depth_mm     double    81 [18.7, 17.4, 18.0, nil, 19.3, ... ], 2 nils
    3 :flipper_length_mm int64     56 [181, 186, 195, nil, 193, ... ], 2 nils
    ```

### `drop`

  Drop some variables (columns) to create a remainer DataFrame.

  ![drop method image](doc/../image/dataframe/drop.png)

- Keys as arguments

  `drop(keys)` accepts keys as arguments in an Array.

- Booleans as a argument

  `drop(booleans)` accepts booleans as a argument in an Array. Booleans must be same length as `n_keys`.

- Keys or booleans by a block

  `drop {block}` is also acceptable. We can't use both arguments and a block at a same time. The block should return keys, or a boolean Array with a same length as `n_keys`. Block is called in the context of self.
  
- Notice for nil

  When used with booleans, nil in booleans is treated as a false. This behavior is aligned with Ruby's `nil#!`.

  ```ruby
  booleans = [true, false, nil]
  booleans_invert = booleans.map(&:!) # => [false, true, true]
  df.pick(booleans) == df.drop(booleans_invert) # => true
  ```
- Difference between `pick`/`drop` and `[]`

  If `pick` or `drop` will select single variable (column), it returns a `DataFrame` with one variable. In contrast, `[]` returns a `Vector`.

  ```ruby
  df = RedAmber::DataFrame.new(a: [1, 2, 3], b: %w[A B C], c: [1.0, 2, 3])
  df[:a]
  # =>
  #<RedAmber::Vector(:uint8, size=3):0x000000000000f258>
  [1, 2, 3]

  df.pick(:a) # or
  df.drop(:b, :c)
  # =>
  #<RedAmber::DataFrame : 3 x 1 Vector, 0x000000000000f280>
  Vector : 1 numeric
  # key type  level data_preview
  1 :a  uint8     3 [1, 2, 3]
  ```

### `slice`

  Slice and select observations (rows) to create a sub DataFrame.

  ![slice method image](doc/../image/dataframe/slice.png)

- Keys as arguments

    `slice(indeces)` accepts indeces as arguments. Indeces should be an Integer or a Range of Integer.

    ```ruby
    # returns 5 obs. at start and 5 obs. from end
    penguins.slice(0...5, -5..-1)
    # =>
    #<RedAmber::DataFrame : 10 x 8 Vectors, 0x000000000000f230>
    Vectors : 5 numeric, 3 strings
    # key                type   level data_preview
    1 :species           string     2 {"Adelie"=>5, "Gentoo"=>5}
    2 :island            string     2 {"Torgersen"=>5, "Biscoe"=>5}
    3 :bill_length_mm    double     9 [39.1, 39.5, 40.3, nil, 36.7, ... ], 2 nils
     ... 5 more Vectors ...
    ```

- Booleans as an argument

  `slice(booleans)` accepts booleans as a argument in an Array, a Vector or an Arrow::BooleanArray . Booleans must be same length as `size`.

    ```ruby
    vector = penguins[:bill_length_mm]
    penguins.slice(vector >= 40)
    # =>
    #<RedAmber::DataFrame : 242 x 8 Vectors, 0x000000000000f2bc>
    Vectors : 5 numeric, 3 strings
    # key                type   level data_preview
    1 :species           string     3 {"Adelie"=>51, "Chinstrap"=>68, "Gentoo"=>123}
    2 :island            string     3 {"Torgersen"=>18, "Biscoe"=>139, "Dream"=>85}
    3 :bill_length_mm    double   115 [40.3, 42.0, 41.1, 42.5, 46.0, ... ]
     ... 5 more Vectors ...
    ```

- Keys or booleans by a block

    `slice {block}` is also acceptable. We can't use both arguments and a block at a same time. The block should return indeces or a boolean Array with a same length as `size`. Block is called in the context of self.

    ```ruby
    # return a DataFrame with bill_length_mm is in 2*std range around mean
    penguins.slice do
      vector = self[:bill_length_mm]
      min = vector.mean - vector.std
      max = vector.mean + vector.std
      vector.to_a.map { |e| (min..max).include? e }
    end
    # =>
    #<RedAmber::DataFrame : 204 x 8 Vectors, 0x000000000000f30c>
    Vectors : 5 numeric, 3 strings
    # key                type   level data_preview
    1 :species           string     3 {"Adelie"=>82, "Chinstrap"=>33, "Gentoo"=>89}
    2 :island            string     3 {"Torgersen"=>31, "Biscoe"=>112, "Dream"=>61}
    3 :bill_length_mm    double    90 [39.1, 39.5, 40.3, 39.3, 38.9, ... ]
     ... 5 more Vectors ...
    ```

- Notice: nil option
  - `Arrow::Table#slice` uses `filter` method with a option `Arrow::FilterOptions.null_selection_behavior = :emit_null`. This will propagate nil at the same row.
    
    ```ruby
    hash = { a: [1, 2, 3], b: %w[A B C], c: [1.0, 2, 3] }
    table = Arrow::Table.new(hash)
    table.slice([true, false, nil])
    # =>
    #<Arrow::Table:0x7fdfe44b9e18 ptr=0x555e9fe744d0>
	         a	b	            c
    0	     1  A      1.000000
    1	(null)	(null)   (null)
    ```

  - Whereas in RedAmber, `DataFrame#slice` with booleans containing nil is treated as false. This behavior comes from `Allow::FilterOptions.null_selection_behavior = :drop`. This is  a default value for `Arrow::Table.filter` method.

    ```ruby
    RedAmber::DataFrame.new(table).slice([true, false, nil]).table
    # =>
    #<Arrow::Table:0x7fdfe44981c8 ptr=0x555e9febc330>
	    a	b	         c
    0	1	A	  1.000000
    ``` 

### `remove`

  Slice and reject observations (rows) to create a remainer DataFrame.

  ![remove method image](doc/../image/dataframe/remove.png)

- Keys as arguments

    `remove(indeces)` accepts indeces as arguments. Indeces should be an Integer or a Range of Integer.

    ```ruby
    # returns 6th to 339th obs.
    penguins.remove(0...5, -5..-1)
    # =>
    #<RedAmber::DataFrame : 334 x 8 Vectors, 0x000000000000f320>
    Vectors : 5 numeric, 3 strings
    # key                type   level data_preview
    1 :species           string     3 {"Adelie"=>147, "Chinstrap"=>68, "Gentoo"=>119}
    2 :island            string     3 {"Torgersen"=>47, "Biscoe"=>163, "Dream"=>124}
    3 :bill_length_mm    double   162 [39.3, 38.9, 39.2, 34.1, 42.0, ... ]
     ... 5 more Vectors ...
    ```

- Booleans as an argument

  `remove(booleans)` accepts booleans as a argument in an Array, a Vector or an Arrow::BooleanArray . Booleans must be same length as `size`.

    ```ruby
    # remove all observation contains nil
    removed = penguins.remove { vectors.map(&:is_nil).reduce(&:|) }
    removed.tdr
    # =>
    RedAmber::DataFrame : 342 x 8 Vectors
    Vectors : 5 numeric, 3 strings
    # key                type   level data_preview
    1 :species           string     3 {"Adelie"=>151, "Chinstrap"=>68, "Gentoo"=>123}
    2 :island            string     3 {"Torgersen"=>51, "Biscoe"=>167, "Dream"=>124}
    3 :bill_length_mm    double   164 [39.1, 39.5, 40.3, 36.7, 39.3, ... ]
    4 :bill_depth_mm     double    80 [18.7, 17.4, 18.0, 19.3, 20.6, ... ]
    5 :flipper_length_mm int64     55 [181, 186, 195, 193, 190, ... ]
    6 :body_mass_g       int64     94 [3750, 3800, 3250, 3450, 3650, ... ]
    7 :sex               string     3 {"male"=>168, "female"=>165, ""=>9}
    8 :year              int64      3 {2007=>109, 2008=>114, 2009=>119}
    ```

- Keys or booleans by a block

    `remove {block}` is also acceptable. We can't use both arguments and a block at a same time. The block should return indeces or a boolean Array with a same length as `size`. Block is called in the context of self.

    ```ruby
    penguins.remove do
      vector = self[:bill_length_mm]
      min = vector.mean - vector.std
      max = vector.mean + vector.std
      vector.to_a.map { |e| (min..max).include? e }
    end
    # =>
    #<RedAmber::DataFrame : 140 x 8 Vectors, 0x000000000000f370>
    Vectors : 5 numeric, 3 strings
    # key                type   level data_preview
    1 :species           string     3 {"Adelie"=>70, "Chinstrap"=>35, "Gentoo"=>35}
    2 :island            string     3 {"Torgersen"=>21, "Biscoe"=>56, "Dream"=>63}
    3 :bill_length_mm    double    75 [nil, 36.7, 34.1, 37.8, 37.8, ... ], 2 nils
     ... 5 more Vectors ...
    ```
- Notice for nil
  - When `remove` used with booleans, nil in booleans is treated as false. This behavior is aligned with Ruby's `nil#!`.

    ```ruby
    df = RedAmber::DataFrame.new(a: [1, 2, nil], b: %w[A B C], c: [1.0, 2, 3])
    booleans = df[:a] < 2
    # =>
    #<RedAmber::Vector(:boolean, size=3):0x000000000000f410>
    [true, false, nil]

    booleans_invert = booleans.to_a.map(&:!) # => [false, true, true]
    df.slice(booleans) == df.remove(booleans_invert) # => true
    ```
  - Whereas `Vector#invert` returns nil for elements nil. This will bring different result.

    ```ruby
    booleans.invert
    # =>
    #<RedAmber::Vector(:boolean, size=3):0x000000000000f488>
    [false, true, nil]

    df.remove(booleans.invert)
    #<RedAmber::DataFrame : 2 x 3 Vectors, 0x000000000000f474>
    Vectors : 2 numeric, 1 string
    # key type   level data_preview
    1 :a  uint8      2 [1, nil], 1 nil
    2 :b  string     2 ["A", "C"]
    3 :c  double     2 [1.0, 3.0]
    ```

### `rename`

  Rename keys (column names) to create a updated DataFrame.

  ![rename method image](doc/../image/dataframe/rename.png)

- Key pairs as arguments

    `rename(key_pairs)` accepts key_pairs as arguments. key_pairs should be a Hash of `{existing_key => new_key}`.

    ```ruby
    h = { 'name' => %w[Yasuko Rui Hinata], 'age' => [68, 49, 28] }
    df = RedAmber::DataFrame.new(h)
    df.rename(:age => :age_in_1993)
    # =>
    #<RedAmber::DataFrame : 3 x 2 Vectors, 0x000000000000f8fc>
    Vectors : 1 numeric, 1 string
    # key          type   level data_preview
    1 :name        string     3 ["Yasuko", "Rui", "Hinata"]
    2 :age_in_1993 uint8      3 [68, 49, 28]
    ```

- Key pairs by a block

    `rename {block}` is also acceptable. We can't use both arguments and a block at a same time. The block should return key_pairs as a Hash of `{existing_key => new_key}`. Block is called in the context of self.

- Key type

  Symbol key and String key are distinguished.

### `assign`

  Assign new variables (columns) and create a updated DataFrame.

  - Variables with new keys will append new variables at bottom (right in the table).
  - Variables with exisiting keys will update corresponding vectors.

    ![assign method image](doc/../image/dataframe/assign.png)

- Variables as arguments

    `assign(key_pairs)` accepts pairs of key and values as arguments. key_pairs should be a Hash of `{key => array}` or `{key => Vector}`.

    ```ruby
    df = RedAmber::DataFrame.new(
      'name' => %w[Yasuko Rui Hinata],
      'age' => [68, 49, 28])
    # =>
    #<RedAmber::DataFrame : 3 x 2 Vectors, 0x000000000000f8fc>
    Vectors : 1 numeric, 1 string
    # key   type   level data_preview
    1 :name string     3 ["Yasuko", "Rui", "Hinata"]
    2 :age  uint8      3 [68, 49, 28]

    # update :age and add :brother
    assigner = { age: [97, 78, 57], brother: ['Santa', nil, 'Momotaro'] }
    df.assign(assigner)
    # =>
    #<RedAmber::DataFrame : 3 x 3 Vectors, 0x000000000000f960>
    Vectors : 1 numeric, 2 strings
    # key      type   level data_preview
    1 :name    string     3 ["Yasuko", "Rui", "Hinata"]
    2 :age     uint8      3 [97, 78, 57]
    3 :brother string     3 ["Santa", nil, "Momotaro"], 1 nil
    ```

- Key pairs by a block

    `assign {block}` is also acceptable. We can't use both arguments and a block at a same time. The block should return pairs of key and values as a Hash of `{key => array}` or `{key => Vector}`. Block is called in the context of self.

    ```ruby
    df = RedAmber::DataFrame.new(
      index: [0, 1, 2, 3, nil],
      float: [0.0, 1.1,  2.2, Float::NAN, nil],
      string: ['A', 'B', 'C', 'D', nil])
    # =>
    #<RedAmber::DataFrame : 5 x 3 Vectors, 0x000000000000f8c0>
    Vectors : 2 numeric, 1 string
    # key     type   level data_preview
    1 :index  uint8      5 [0, 1, 2, 3, nil], 1 nil
    2 :float  double     5 [0.0, 1.1, 2.2, NaN, nil], 1 NaN, 1 nil
    3 :string string     5 ["A", "B", "C", "D", nil], 1 nil

    # update numeric variables
    df.assign do
      assigner = {}
      vectors.each_with_index do |v, i|
        assigner[keys[i]] = v * -1 if v.numeric?
      end
      assigner
    end
    # =>
    #<RedAmber::DataFrame : 5 x 3 Vectors, 0x000000000000f924>
    Vectors : 2 numeric, 1 string
    # key     type   level data_preview
    1 :index  int8       5 [0, -1, -2, -3, nil], 1 nil
    2 :float  double     5 [-0.0, -1.1, -2.2, NaN, nil], 1 NaN, 1 nil
    3 :string string     5 ["A", "B", "C", "D", nil], 1 nil
    ```

- Key type

  Symbol key and String key are considered as the same key.

## Updating

- [ ] Update elements matching a condition

- [ ] Clamp

- [ ] Sort rows

- [ ] Clear data

## Treat na data

- [ ] Drop na (NaN, nil)

- [ ] Replace na with value

- [ ] Interpolate na with convolution array

## Combining DataFrames

- [ ]  obs

- [ ] Add vars

- [ ] Inner join

- [ ] Left join

## Encoding

- [ ] One-hot encoding

## Iteration (not impremented)