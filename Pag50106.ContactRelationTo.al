page 50106 "Contact Relation To"
{

    PageType = API;
    APIGroup = 'queries';
    APIPublisher = 'publisher';
    APIVersion = 'v1.0';
    EntityName = 'contactRelationTo';
    EntitySetName = 'contactRelationsTo';
    ODataKeyFields = "No.";
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
                field(relationToContactNo; "Relation to Contact No.") { }
            }
        }
    }
}
