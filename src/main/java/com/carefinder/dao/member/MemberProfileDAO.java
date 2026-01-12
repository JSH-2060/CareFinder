package com.carefinder.dao.member;

import com.carefinder.dto.member.MemberProfileDTO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface MemberProfileDAO {
    MemberProfileDTO findByMno(Long mno);
}
