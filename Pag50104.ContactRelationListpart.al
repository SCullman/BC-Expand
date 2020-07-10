page 50104 "Contact Relation Listpart"
{

    Caption = 'Contact Relations';
    PageType = ListPart;
    SourceTable = "Contact Relation";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Contact No."; "Contact No.")
                {
                    ApplicationArea = All;
                }
                field("Contact Name"; "Contact Name")
                {
                    ApplicationArea = All;
                }
                field("Description"; Description)
                {
                    ApplicationArea = All;
                }
                field("Relation to Contact No."; "Relation to Contact No.")
                {
                    ApplicationArea = All;
                }
                field("Relation to Contact Name"; "Relation to Contact Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
