pageextension 50105 "ContectRelationExtension" extends "Contact Card"
{
    layout
    {

        addafter(General)
        {
            group("ContactRelGroup")
            {
                Caption = 'Contact Relations';
                part("Contact Relations"; "Contact Relation Listpart")
                {
                    SubPageLink = "Contact No." = FIELD("No.");
                    Visible = false;
                }
            }

        }
    }
}