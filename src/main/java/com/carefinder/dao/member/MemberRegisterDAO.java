package com.carefinder.dao.member;

import com.carefinder.dto.member.MemberRegisterDTO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface MemberRegisterDAO {

    int insertNormalMember(MemberRegisterDTO member);

    MemberRegisterDTO findNormalMemberById(String id);

    int checkIdDuplicate(String id);
}
