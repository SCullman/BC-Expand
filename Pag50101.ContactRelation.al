page 50101 "Contact Relation"
{
    ApplicationArea = All;
    Caption = 'Contact Relations';
    PageType = List;
    SourceTable = "Contact Relation";
    UsageCategory = Lists;

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
