
gk_nc31_dialog : dialog {
 label = "��������� ���������� ���������";
 :column{
	alignment = right;
	fixed_width=true; //����������� ������ �� �������� ������
	:column{
	
		label = "�������� :";
		:toggle{
			label="�� ������������ ������� +/-45";
			key = "t_45";
			value = "0";
			}
		:row{
			alignment = left;
			:text{
				label="������������ ������� ��� ����� �� ���";
				}
			:radio_column{
				:radio_button{
					label = "�";
					key = "rb_X";
					value = "1";
					}
				:radio_button{
					label = "Z";
					key = "rb_Z";
					}
				}
			}

				
		:row{
			alignment = left;
			:toggle{
				label="������, ������������ ��� ����� - F " ;
				key="t_F";
				}
			:edit_box{
				alignment = left;
				value="0";
				key="eb_F";
				
				}
			}
		:toggle{
			label="������� �� ���������� ������ � 1 ����� � ����������";
			key="t_~";
			value="1";
			}
		:toggle{
			label="���������� ��������� 'P' � �������� G2/G3";
			key="t_argum_p";
			value="0";
			}
	}
		
	:spacer{}
	:column{
		label="�������������� :";
		:row{
			:text{
				label="��� ����� ��� ���������� �� ";
				}
			
			:edit_box{
				value="��.xls";
				key="eb_file_name";
				}
			}
		:spacer{}
		}

	ok_cancel;
	}
}
