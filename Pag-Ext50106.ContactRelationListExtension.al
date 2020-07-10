pageextension 50106 "ContactRelationListExtension" extends "Contact List"
{
    layout
    {
        addafter(Control1)
        {
            group("ContactRelGroup")
            {
                part("Relations"; "Contact Relation Listpart")
                {
                    SubPageLink = "Contact No." = FIELD("No.");
                }
            }
        }
    }
}