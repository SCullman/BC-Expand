page 50103 "Contact Api"
{

    APIGroup = 'nav';
    APIPublisher = 'publisher';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    EntityName = 'contact';
    EntitySetName = 'contacts';
    PageType = API;
    SourceTable = Contact;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(number; "No.")
                {
                    ApplicationArea = All;
                    Caption = 'number', Locked = true;
                }
                field(firstName; "First Name")
                {
                    ApplicationArea = All;
                    Caption = 'firstName', Locked = true;
                }
                field(surname; Surname)
                {
                    ApplicationArea = All;
                    Caption = 'surname', Locked = true;
                }
                field(name; Name)
                {
                    ApplicationArea = All;
                    Caption = 'name', locked = true;
                }
                field(id; SystemId)
                {
                    ApplicationArea = All;
                    Caption = 'id';
                }
                field(companyNo; "Company No.")
                {
                    ApplicationArea = All;
                    Caption = 'companyNo';
                }

                part(relations; 50102)
                {
                    ApplicationArea = All;
                    EntityName = 'relation';
                    EntitySetName = 'relations';
                }
            }
        }
    }

}
