# LUAU-DataServer
This script is specifically made for roblox. It makes easy Data Importing, modifying and Saving. This script will import the data and secure a minimal data integrity, you just have to put the initial data on the dictionary DataHelper.DataSkeleton. For example

    DataHelper.DataSkeleton = {
    
      ["Coins"] = 10;
      ["WeaponsOwned"] = {"Sword", "Gun"};
    
    }

The script will make sure the values are the same kind, so in case you change something, let's asy you change Coins to a table, it will see they're not the same kind of data and correct it. You can make minimal safety checks on DataHelper.CorrectData(), like for example, in case you add another weapon to the initial ones, make sure old players own it by looping like this.


    function module.CorrectData(data: {})
    
      for _, weapon in DataHelper.DataSkeleton.WeaponsOwned
        if table.find(data.WeaponsOwned, weapon) then continue end
        
        table.insert(data.WeaponsOwned, weapon)
        
        return data
      end
    end

In case you want to remove a value from data, follow the next example. Careful when editing data to make sure users are not able to hardinsert this to the data, so make sure to make safe code.

    DataHelper.DataSkeleton = {
    
      ["Coins"] = {RemoveFromData = true};
    
    }
