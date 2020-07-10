page 50102 "Contact Relation Api"
{

    APIGroup = 'queries';
    APIPublisher = 'publisher';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    EntityName = 'contactRelation';
    EntitySetName = 'contactRelations';
    ODataKeyFields = "No.";
    PageType = API;
    SourceTable = "Contact Relation";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(number; "No.") { }
                field(contactNo; "Contact No.") { }
                field(description; "Description") { }
                field(relationToContactNo; "Relation to Contact No.") { }
            }
        }
    }
}
