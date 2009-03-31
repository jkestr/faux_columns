Faux Columns
============

_Developed by Matt Puchlerz, The Killswitch Collective ([killswitchcollective.com](http://killswitchcollective.com)) 03.20.2009_

I don't like using serialized data. I find that most people use it too much, especially since Rails makes it so easy. `serialize :column_name` and you're done--almost too simple. Yet on the very rare occasion that it makes sense to use, there are still a few annoyances; namely having to reference all data through the aforementioned `column_name`.

In many cases it would be more convenient just to reference the attributes within the serialized data column as if they were real attributes. That way there'd be no question what data is being serialized, and you could continue using your form builders as you always have.

The **Faux Columns** plugin attempts to provide this functionality.

Using the Plugin
----------------

    class MyModel < ActiveRecord::Base
    
      faux_columns_in( :actual_column_name, 
                       [ :attribute1 => ClassName, 
                         :attribute2 => ClassName ] )
      
    end
  
Or perhaps a more real-world scenario...

    class MyHouse < ActiveRecord::Base
    
      faux_columns_in :data,
        :kitchen_cabinets       => Integer,
        :driving_directions     => String,
        :new_roof_installed_on  => Date,
        :nearby_developments    => String,
        :overall_height         => Float
      
    end

In the example above, calling the `faux_columns_in` method within the given `MyHouse` model class automatically does the following:

1. Sets up serialization of the `data` column
2. Creates accessors for each of the symbol keys in the passed in the array of desired attributes

Now you can read and write to the _Faux Column_ attributes just like regular attributes.

    house = MyHouse.new
  
    house.kitchen_cabinets = 12
    house.driving_directions = "Head south on route 123, turn left at the light."
  
    house.kitchen_cabinets          # => 12
    house.data.driving_directions   # => "Head south on route 123, turn left at the light."

