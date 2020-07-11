page 50107 "Contact Relation From"
{

    APIGroup = 'queries';
    APIPublisher = 'publisher';
    APIVersion = 'v1.0';
    EntityName = 'contactRelationFrom';
    EntitySetName = 'contactRelationsFrom';
    ODataKeyFields = "No.";
    PageType = API;
    SourceTable = "Contact Relation";
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    DelayedInsert = true;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(number; "No.") { }
                field(description; "Description") { }
                field(contactNo; "Contact No.") { }
            }
        }
    }
}
