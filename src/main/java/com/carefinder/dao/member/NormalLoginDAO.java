package com.carefinder.dao.member;

import com.carefinder.dto.member.NormalLoginDTO;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

@Repository
@Mapper
public interface NormalLoginDAO {
    NormalLoginDTO findById(@org.apache.ibatis.annotations.Param("id") String id);
}
