package com.carefinder.dao.member;

import com.carefinder.dto.member.MemberKakaoDTO;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

@Repository
@RequiredArgsConstructor
public class MemberKakaoDAOImpl implements MemberKakaoDAO {

    private final SqlSession sqlSession;
    private static final String NS = "member.";

    @Override
    public MemberKakaoDTO findById(String id) {
        return sqlSession.selectOne(NS + "findById", id);
    }

    @Override
    public MemberKakaoDTO findByKakaoId(String kakaoId) {
        return sqlSession.selectOne(NS + "findByKakaoId", kakaoId);
    }

    @Override
    public void insertMember(MemberKakaoDTO member) {
        sqlSession.insert(NS + "insertMember", member);
    }

    @Override
    public void insertKakaoMember(MemberKakaoDTO member) {
        sqlSession.insert(NS + "insertKakaoMember", member);
    }
}

