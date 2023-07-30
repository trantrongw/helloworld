// This file contains your Data Connector logic
[Version = "1.0.0"]
section helloworld;
BaseUrl = "https://services.odata.org/v4/TripPinService/";
[DataSource.Kind="helloworld", Publish="helloworld.Publish"]
shared helloworld.Contents = (message as text) =>
    let
        a = NavTable(message)
    in
        a;
NavTable = (message as text) as table =>
    let
        source = #table({"Name", "Data", "ItemKind", "ItemName", "IsLeaf"}, {
            { "helloworld1", helloworld1(message), "Table", "Table", true },
            { "helloworld2", helloworld2(message), "Table", "Table", true }
        }),
        navTable = Table.ToNavigationTable(source, {"Name"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        navTable;
RootEntities = {
    "helloworld1",
    "helloworld2"
};
helloworld1 = (message as text) as table =>
    let
        source = message&"helloworld1",
        #"Converted to Table" = #table(1, {{source}}),
        #"Renamed Columns" = Table.RenameColumns(#"Converted to Table",{{"Column1", "name"}}),
        #"Changed Type" = Table.TransformColumnTypes(#"Renamed Columns",{{"name", type text}})
    in
        #"Changed Type";
helloworld2 = (message as text) as table =>
   let
        source = message&"helloworld2",
        #"Converted to Table" = #table(1, {{source}}),
        #"Renamed Columns" = Table.RenameColumns(#"Converted to Table",{{"Column1", "name"}}),
        #"Changed Type" = Table.TransformColumnTypes(#"Renamed Columns",{{"name", type text}})
    in
        #"Changed Type";
// Data Source Kind description
helloworld = [
    TestConnection = (dataSourcePath) => 
    let
        message = "test"
    in
        message
    
    ,
    Authentication = [
        Anonymous = []
    ]
];

// Data Source UI publishing description
helloworld.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = helloworld.Icons,
    SourceTypeImage = helloworld.Icons
];

helloworld.Icons = [
    Icon16 = { Extension.Contents("helloworld16.png"), Extension.Contents("helloworld20.png"), Extension.Contents("helloworld24.png"), Extension.Contents("helloworld32.png") },
    Icon32 = { Extension.Contents("helloworld32.png"), Extension.Contents("helloworld40.png"), Extension.Contents("helloworld48.png"), Extension.Contents("helloworld64.png") }
];

Table.ToNavigationTable = (
    table as table,
    keyColumns as list,
    nameColumn as text,
    dataColumn as text,
    itemKindColumn as text,
    itemNameColumn as text,
    isLeafColumn as text
) as table =>
    let
        tableType = Value.Type(table),
        newTableType = Type.AddTableKey(tableType, keyColumns, true) meta 
        [
            NavigationTable.NameColumn = nameColumn, 
            NavigationTable.DataColumn = dataColumn,
            NavigationTable.ItemKindColumn = itemKindColumn, 
            Preview.DelayColumn = itemNameColumn, 
            NavigationTable.IsLeafColumn = isLeafColumn
        ],
        navigationTable = Value.ReplaceType(table, newTableType)
    in
        navigationTable;