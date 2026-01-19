package com.carefinder.service.member;

import org.springframework.stereotype.Service;

import com.carefinder.dao.member.MemberAccountDAO;
import com.carefinder.dto.member.MemberAccountDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MemberAccountService {

    private final MemberAccountDAO memberAccountDAO;

    /* 마이페이지 계정 정보 조회 */
    public MemberAccountDTO getAccountInfo(Long mno) {
        return memberAccountDAO.findByMno(mno);
    }

    /* 마이페이지 계정 정보 수정 */
    public void updateAccountInfo(MemberAccountDTO dto) {
        memberAccountDAO.updateAccountInfo(dto);
    }

    /* 회원 탈퇴 */
    public void withdraw(Long mno) {
        memberAccountDAO.withdraw(mno);
    }
}
