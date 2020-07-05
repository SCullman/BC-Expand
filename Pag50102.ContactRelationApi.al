page 50102 "Contact Relation Api"
{

    APIGroup = 'nav';
    APIPublisher = 'publisher';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    EntityName = 'relation';
    EntitySetName = 'relations';
    ODataKeyFields = "No.";
    PageType = API;
    SourceTable = "Contact Relation";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(number; "No.")
                {
                    ApplicationArea = All;
                    Caption = 'no';
                }
                field(contactNo; "Contact No.")
                {
                    ApplicationArea = All;
                    Caption = 'contactNo';
                }
                field(relationToContactNo; "Relation to Contact No.")
                {
                    ApplicationArea = All;
                    Caption = 'relationToContactNo';
                }
                field(description; "Description")
                {
                    ApplicationArea = All;
                    Caption = 'description';
                }
            }
        }
    }
}
