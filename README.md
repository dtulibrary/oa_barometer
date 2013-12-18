oa_barometer
============
This application relies on at dataset created by the scripts placed in the /script folder.

The resulting dataset consists of data from the following sources:

* BFI
* DDF
* DOAJ
* Sherpa/RoMeO

The BFI data is provided as a spreadsheet obtained directly from BFI.

The DDF data is harvested by the 'harvest_ddf' script located in the script-folder. Execution of this script requires two parameters:

1. The server on which the database is located (Zebra)

2. The port used for queries for the database.

Notice! Adjust the variable 'years' in the 'harvest_ddf' script to change the included years. Be aware that it is reasonable to add the adjacent years, since years in DDF are more 'fluent' than the 'snapshot' taken in BFI data.

The DOAJ data can be obtained directly from their website in CSV format.

The Sherpa/RoMeO data is obtained through use of their API (a script has been made by Franck to collect the data; the script is not part of this project)

Once the data is collected, place each file in script/data/.

The 'create_oa_dataset' script create the dataset, but the check the following before you run it:

1. Verify and correct the filenames of the datafiles.

2. Verify that the worksheet name is still correct for the BFI and Sherpa/RoMeO spreadsheet.

Notice! The scripts are tightly coupled to the formats from each source, so if changes occur it will be important to adjust the indices used in the script. 

Finally, run the 'create_oa_dataset' script to create the dataset. The script will output the following files:

1. oa_barometer.xls (spreadsheet containing the resulting dataset)

2. oa_barometer.csv (csv-file containing the resulting dataset; content is identical to 'oa_barometer.xls')

3. journal_top.json (json-file that contains sorted information about the most popular journals; used in rails application)

4. oa_barometer.json (json-file that contains various information about publications, topics, institutions, etc.; used in rails application)

5. rt_tree.json (json-file that describes the structure of 'oa_barometer.json' in a node structure; used in rails application for the Reingold Tilford Tree visualization)
