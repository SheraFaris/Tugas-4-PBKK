import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateLikeDto } from './dto/create-like.dto';
import { UpdateLikeDto } from './dto/update-like.dto';
import { Like } from './entities/like.entity';

@Injectable()
export class LikesService {
  constructor(
    @InjectRepository(Like)
    private readonly likeRepository: Repository<Like>,
  ) {}

  async create(createLikeDto: CreateLikeDto): Promise<Like> {
    const like = this.likeRepository.create(createLikeDto);
    return this.likeRepository.save(like);
  }

  async findAll(): Promise<Like[]> {
    return this.likeRepository.find();
  }

  async findOne(id: number): Promise<Like> {
    return this.likeRepository.findOne({ where: { id } });
  }

  async update(id: number, updateLikeDto: UpdateLikeDto): Promise<Like> {
    await this.likeRepository.update(id, updateLikeDto);
    return this.findOne(id);
  }

  async remove(id: number): Promise<void> {
    await this.likeRepository.delete(id);
  }
}
