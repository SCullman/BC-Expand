table 50100 "Contact Relation"
{
    Caption = 'Contact Relation';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[10])
        {
            Caption = 'Entry No';
            DataClassification = CustomerContent;
        }
        field(2; "Contact No."; Code[20])
        {
            TableRelation = Contact."No.";
        }
        field(3; "Relation to Contact No."; Code[20])
        {
            TableRelation = Contact."No.";

        }
        field(4; "Description"; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(5; "Contact Name"; Text[50])
        {
            FieldClass = FlowField;
            CalcFormula = lookup (Contact.Name where("No." = field("Contact No.")));
        }
        field(6; "Relation to Contact Name"; Text[50])
        {
            FieldClass = FlowField;
            CalcFormula = lookup (Contact.Name where("No." = field("Relation to Contact No.")));
        }
    }
    keys { key(PK; "No.") { } }
}
