number_cp : dialog {
 label = "���������...";
//		fixed_width=true;
//		fixed_height=true;
		alignment = left;
		fixed_width = true;
	:column{
		fixed_width=true;
		fixed_height=true;
		label = "������� ����� �����, � ��������";
		:text{
			label=" ����� ��������� �� � ���� Excel:";
			fixed_width = true;
			}
		alignment = left;
		:edit_box{
			alignment = centered;
			value = 0;
			key = "eb_numner_cp";
			fixed_width = true;
			}
		
		ok_cancel;
		}
	
}