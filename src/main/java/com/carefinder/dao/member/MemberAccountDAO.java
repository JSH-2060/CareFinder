package com.carefinder.dao.member;

import com.carefinder.dto.member.MemberAccountDTO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface MemberAccountDAO {

    MemberAccountDTO findByMno(Long mno);

    void updateAccountInfo(MemberAccountDTO dto);

    void withdraw(Long mno);
}
