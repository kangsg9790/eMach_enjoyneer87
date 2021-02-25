# -*- coding: utf-8 -*-
"""
Created on Sat Feb 20 13:35:27 2021

@author: Bharat
"""

class TokenDraw():
    '''
    This class acts as a wrapper of information generated when drawing a line 
    or an arc using emach
    '''
    
    def __init__(self, draw_token: any, geometry_type: int) -> None :
        '''
        

        Parameters
        ----------
        segment_indices : Any
            This is the return value obtained from the drawer tool upon drawing
            a line or an arc.
            
        segment_type : int
            This specifies whether the segment drawn is a line or an arc. 1 
            represents arcs and 0 represents lines

        Returns
        -------
        None.

        '''
        self.__draw_token = draw_token
        self.__geometry_type = geometry_type

    @property
    def draw_token(self):
        return self.__draw_token
    
    @property
    def geometry_type(self):
        return self.__geometry_type   
        